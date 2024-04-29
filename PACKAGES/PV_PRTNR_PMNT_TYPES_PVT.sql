--------------------------------------------------------
--  DDL for Package PV_PRTNR_PMNT_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRTNR_PMNT_TYPES_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvptss.pls 120.1 2005/08/05 18:39:28 appldev ship $ */


PROCEDURE Get_prtnr_payment_types(
     p_partner_party_id           IN   NUMBER
    ,x_payment_type_tbl           OUT  NOCOPY   JTF_VARCHAR2_TABLE_200
    ,x_is_po_number_enabled	  OUT  NOCOPY   VARCHAR2
);

END PV_PRTNR_PMNT_TYPES_PVT;

 

/
