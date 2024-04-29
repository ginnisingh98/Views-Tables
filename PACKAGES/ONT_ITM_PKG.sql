--------------------------------------------------------
--  DDL for Package ONT_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_ITM_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXVITMS.pls 120.2.12010000.6 2010/04/15 05:06:22 sahvivek ship $ */

TYPE Address_rec_type IS  RECORD
(
  add_source_type               VARCHAR2(30),
  add_source_orgid              NUMBER,
  add_contact_id                NUMBER,
  add_party_name                VARCHAR2(360),
  add_alternate_name            VARCHAR2(320), --bug 4231894
  add_party_address1            VARCHAR2(2000),
  add_party_address2            VARCHAR2(2000),
  add_party_address3            VARCHAR2(2000),
  add_party_address4            VARCHAR2(2000),
  add_party_city                VARCHAR2(60),
  add_party_state               VARCHAR2(60),
  add_party_country             VARCHAR2(60),
  add_party_postal_code         VARCHAR2(60),
  add_party_phone               VARCHAR2(80),
  add_party_email               VARCHAR2(2000),
  add_party_fax                 VARCHAR2(80),
  add_party_url                 VARCHAR2(2000),
  add_party_contact_name        VARCHAR2(360),
  add_hz_party_id               NUMBER(15),   --Bug 9583024
  add_hz_party_number           VARCHAR2(30), --Bug 9583024
  add_party_site_number         VARCHAR2(30), --Bug 9583024
  add_contact_hz_party_id       NUMBER(15),   --Bug 9583024
  add_contact_hz_party_number   VARCHAR2(30)  --Bug 9583024
);



TYPE Address_table_type IS TABLE OF Address_rec_type
INDEX BY BINARY_INTEGER;

Address_table Address_table_type;



PROCEDURE Process_ITM_REQUEST (
            p_line_rec                   IN  OE_Order_PUB.Line_Rec_Type,
x_return_status OUT NOCOPY VARCHAR2,

x_result_out OUT NOCOPY VARCHAR2);

PROCEDURE  Get_Address (
	    p_source_id    		 IN  NUMBER,
	    p_source_type   		 IN  VARCHAR2,
	    p_contact_id		 IN  NUMBER,
	    p_org_id_passed              IN  VARCHAR2, -- bug 9130718
            x_party_name OUT NOCOPY VARCHAR2,
            x_alternate_name OUT NOCOPY VARCHAR2, -- bug 4231894
            x_address1 OUT NOCOPY VARCHAR2,
	    x_address2 OUT NOCOPY VARCHAR2,
	    x_address3 OUT NOCOPY VARCHAR2,
	    x_address4 OUT NOCOPY VARCHAR2,
            x_city OUT NOCOPY VARCHAR2,
            x_state OUT NOCOPY VARCHAR2,
            x_country OUT NOCOPY VARCHAR2,
            x_postal_code OUT NOCOPY VARCHAR2,
            x_phone OUT NOCOPY VARCHAR2,
            x_email OUT NOCOPY VARCHAR2,
            x_fax OUT NOCOPY VARCHAR2,
            x_url OUT NOCOPY VARCHAR2,
            x_contact_person OUT NOCOPY VARCHAR2,
            x_hz_party_id                OUT NOCOPY NUMBER,   --Bug 9583024
            x_hz_party_number            OUT NOCOPY VARCHAR2, --Bug 9583024
            x_party_site_number          OUT NOCOPY VARCHAR2, --Bug 9583024
            x_contact_hz_party_id        OUT NOCOPY NUMBER,   --Bug 9583024
            x_contact_hz_party_number    OUT NOCOPY VARCHAR2, --Bug 9583024
            x_return_status              OUT NOCOPY VARCHAR2);


PROCEDURE Update_Process_Flag(
                        p_line_id     IN  NUMBER
                         );

PROCEDURE Init_Address_Table;


PROCEDURE Create_Request(
            p_master_organization_id     IN  NUMBER,
            p_line_rec                   IN  OE_ORDER_PUB.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE WSH_ITM_ONT(
            p_request_control_id         IN   NUMBER    default null,
            p_request_set_id             IN   NUMBER    default null,
            p_status_code                IN   VARCHAR2  default null);

END ONT_ITM_PKG;

/
