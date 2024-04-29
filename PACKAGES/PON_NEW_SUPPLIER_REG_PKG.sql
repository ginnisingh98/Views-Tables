--------------------------------------------------------
--  DDL for Package PON_NEW_SUPPLIER_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_NEW_SUPPLIER_REG_PKG" AUTHID CURRENT_USER AS
-- $Header: PONNSRS.pls 120.0 2005/06/01 19:54:33 appldev noship $
PROCEDURE SRC_POS_REG_SUPPLIER_CALLBACK
  (
   x_return_status	      OUT NOCOPY  VARCHAR2,
   x_msg_count		      OUT NOCOPY  NUMBER,
   x_msg_data		      OUT NOCOPY  VARCHAR2,
   p_requested_supplier_id    IN          NUMBER,
   p_po_vendor_id 	      IN          NUMBER,
   p_supplier_hz_party_id     IN          NUMBER,
   p_user_id		      IN          NUMBER
  );
--
END PON_NEW_SUPPLIER_REG_PKG;

 

/
