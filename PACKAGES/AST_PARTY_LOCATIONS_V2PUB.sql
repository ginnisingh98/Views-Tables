--------------------------------------------------------
--  DDL for Package AST_PARTY_LOCATIONS_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_PARTY_LOCATIONS_V2PUB" AUTHID CURRENT_USER AS
 /* $Header: astcul2s.pls 115.1 2002/12/05 18:46:19 rnori ship $ */

   PROCEDURE Create_Address (
     p_address_rec       IN   AST_API_RECORDS_V2PKG.ADDRESS_REC_TYPE,
     x_msg_count         OUT NOCOPY  NUMBER,
     x_msg_data          OUT NOCOPY  VARCHAR2,
     x_return_status     OUT NOCOPY  VARCHAR2,
     x_location_id       OUT NOCOPY  NUMBER);

   PROCEDURE Update_Address (
     p_address_rec           IN     AST_API_RECORDS_V2PKG.ADDRESS_REC_TYPE,
	p_object_version_number IN OUT NOCOPY NUMBER,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2);

END AST_PARTY_LOCATIONS_V2PUB;

 

/
