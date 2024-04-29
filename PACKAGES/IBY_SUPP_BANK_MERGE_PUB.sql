--------------------------------------------------------
--  DDL for Package IBY_SUPP_BANK_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_SUPP_BANK_MERGE_PUB" AUTHID CURRENT_USER AS
/* $Header: ibybnkmergs.pls 120.0.12010000.1 2010/04/21 11:48:25 appldev noship $ */

  TYPE Id_Tab_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  --
  -- Updates credit credit card owners during party merge;
  -- updates billing address during party site use merge.
  --
  PROCEDURE BANK_ACCOUNTS_MERGE (
   P_from_vendor_id		IN     NUMBER,
   P_to_vendor_id		IN     NUMBER,
   P_from_party_id		IN     NUMBER,
   P_to_party_id		IN     NUMBER,
   P_from_vendor_site_id	IN     NUMBER,
   P_to_vendor_site_id		IN     NUMBER,
   P_from_party_site_id		IN     NUMBER,
   P_to_partysite_id		IN     NUMBER,
   P_from_org_id		IN     NUMBER,
   P_to_org_id			IN     NUMBER,
   P_from_org_type		IN     VARCHAR2,
   P_to_org_type		IN     VARCHAR2,
   p_keep_site_flag		IN     VARCHAR2,
   p_last_site_flag		IN     VARCHAR2,
   X_return_status		IN     OUT NOCOPY VARCHAR2,
   X_msg_count			IN     OUT NOCOPY NUMBER,
   X_msg_data			IN     OUT NOCOPY VARCHAR2
);


END IBY_SUPP_BANK_MERGE_PUB;

/
