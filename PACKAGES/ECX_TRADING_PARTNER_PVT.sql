--------------------------------------------------------
--  DDL for Package ECX_TRADING_PARTNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_TRADING_PARTNER_PVT" AUTHID CURRENT_USER AS
-- $Header: ECXTPXFS.pls 120.5 2005/10/31 00:43:08 susaha ship $
G_BANK		CONSTANT	VARCHAR2(10) := 'BANK';
G_CUSTOMER	CONSTANT	VARCHAR2(10) := 'CUSTOMER';
G_SUPPLIER	CONSTANT	VARCHAR2(10) := 'SUPPLIER';
G_LOCATION	CONSTANT	VARCHAR2(10) := 'LOCATION';

g_oag_logicalid	varchar2(2000);

/** Returns the trading partners Details as defined in the partner Setup **/
procedure get_tp_info
	(
	p_tp_header_id		IN	pls_integer,
	p_party_id		OUT	NOCOPY NUMBER,
	p_party_site_id		OUT	NOCOPY NUMBER,
	p_org_id		OUT	NOCOPY pls_integer,
	p_admin_email		OUT	NOCOPY varchar2,
	retcode			OUT	NOCOPY pls_integer,
	retmsg			OUT	NOCOPY varchar2
	);

/** Returns the address_id for a given address_type **/
PROCEDURE Get_Address_id
	(
	p_location_code_ext	IN	VARCHAR2,
	p_info_type		IN	VARCHAR2,
	p_entity_address_id	OUT	NOCOPY pls_integer,
	p_org_id		OUT	NOCOPY pls_integer,
	retcode			OUT	NOCOPY pls_integer,
	retmsg			OUT	NOCOPY varchar2
	);

/** Uses the Global variables for the Inbound Transaction **/
/** Receivers TP Info **/
procedure get_receivers_tp_info
	(
	p_party_id		OUT	NOCOPY NUMBER,
	p_party_site_id		OUT	NOCOPY NUMBER,
	p_org_id		OUT	NOCOPY pls_integer,
	p_admin_email		OUT	NOCOPY varchar2,
	retcode			OUT	NOCOPY pls_integer,
	retmsg			OUT	NOCOPY varchar2
	);

/** Senders TP Info **/
procedure get_senders_tp_info
	(
	p_party_id		OUT	NOCOPY NUMBER,
	p_party_site_id		OUT	NOCOPY NUMBER,
	p_org_id		OUT	NOCOPY pls_integer,
	p_admin_email		OUT	NOCOPY varchar2,
	retcode			OUT	NOCOPY pls_integer,
	retmsg			OUT	NOCOPY varchar2
	);

/** Get TP Company  email ****/
procedure get_tp_company_email
        (
         l_transaction_type     IN  varchar2,
         l_transaction_subtype  IN  varchar2,
         l_party_site_id  	IN  number,
         l_party_type           IN  varchar2 default null, --bug #2183619
         l_email_addr     	OUT NOCOPY varchar2,
	 retcode          	OUT NOCOPY pls_integer,
	 errmsg		 	OUT NOCOPY varchar2
        );

/** Get System Adminstrator Email   ***/
procedure get_sysadmin_email
        (
          email_address OUT NOCOPY varchar2,
          retcode       OUT NOCOPY pls_integer,
          errmsg        OUT NOCOPY varchar2
        );

/** Get TP Details given party_type, party_id, party_site_id, trxn type trxn subtype ***/
procedure get_tp_details
        (
          p_party_type          IN  varchar2,
          p_party_id            IN  number,
          p_party_site_id       IN  number,
          p_transaction_type    IN  varchar2,
          p_transaction_subtype IN  varchar2,
          p_protocol_type       OUT NOCOPY varchar2,
          p_protocol_address    OUT NOCOPY varchar2,
          p_username            OUT NOCOPY varchar2,
          p_password            OUT NOCOPY varchar2,
          p_retcode             OUT NOCOPY pls_integer,
          p_errmsg              OUT NOCOPY varchar2
        );

/** Get error type***/
procedure get_error_type
        (
           i_error_type        	OUT     NOCOPY pls_integer,
           retcode              OUT     NOCOPY pls_integer,
           errmsg               OUT     NOCOPY varchar2
        );

procedure getEnvelopeInformation
	(
	i_internal_control_number	in      pls_integer,
	i_message_type                  OUT     NOCOPY varchar2,
	i_message_standard              OUT     NOCOPY varchar2,
	i_transaction_type              OUT     NOCOPY varchar2,
	i_transaction_subtype           OUT     NOCOPY varchar2,
	i_document_number               OUT     NOCOPY varchar2,
	i_party_id                      OUT     NOCOPY varchar2,
	i_party_site_id                 OUT     NOCOPY varchar2,
	i_protocol_type                 OUT     NOCOPY varchar2,
	i_protocol_address              OUT     NOCOPY varchar2,
	i_username                      OUT     NOCOPY varchar2,
	i_password                      OUT     NOCOPY varchar2,
	i_attribute1                    OUT     NOCOPY varchar2,
	i_attribute2                    OUT     NOCOPY varchar2,
	i_attribute3                    OUT     NOCOPY varchar2,
	i_attribute4                    OUT     NOCOPY varchar2,
	i_attribute5                    OUT     NOCOPY varchar2,
	retcode				OUT	NOCOPY pls_integer,
	retmsg				OUT	NOCOPY varchar2
	);

procedure setOriginalReferenceId
	(
	i_internal_control_number       in      varchar2,
	i_original_reference_id         in      varchar2,
	retcode                 	OUT     NOCOPY pls_integer,
	retmsg                  	OUT     NOCOPY varchar2
	);
function getOAGLOGICALID
	return varchar2;

Function IsUserAuthorized (p_user_name IN VARCHAR2,
	                   p_tp_header_id IN PLS_INTEGER,
                           p_profile_value  IN VARCHAR2 default null)
   Return Boolean;

Function validateTPUser (
	  p_transaction_type     IN VARCHAR2,
	  p_transaction_subtype  IN VARCHAR2,
	  p_standard_code        IN VARCHAR2,
	  p_standard_type        IN VARCHAR2,
	  p_party_site_id        IN VARCHAR2,
	  p_user_name            IN VARCHAR2,
	  x_tp_header_id         OUT NOCOPY NUMBER,
	  retcode                OUT NOCOPY VARCHAR2,
	  errmsg                 OUT NOCOPY VARCHAR2)
 return varchar2;

END ECX_TRADING_PARTNER_PVT;

 

/
