--------------------------------------------------------
--  DDL for Package RCV_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: RCVUTILS.pls 120.1.12010000.4 2014/02/26 20:48:32 vthevark noship $*/

Procedure Merge_Vendor
          ( p_commit             IN   VARCHAR2 default FND_API.G_FALSE,
            x_return_status      OUT  NOCOPY   VARCHAR2,
            x_msg_count          OUT  NOCOPY   NUMBER,
            x_msg_data           OUT  NOCOPY   VARCHAR2,
            p_vendor_id          IN   NUMBER,
            p_vendor_site_id     IN   NUMBER,
            p_dup_vendor_id      IN   NUMBER,
            p_dup_vendor_site_id IN   NUMBER
          );

-- Bug 7579045: This API is used by AP for AP-LCM integration.
Procedure Get_RtLcmInfo
          ( p_rcv_transaction_id             IN  NUMBER,
            x_lcm_account_id                 OUT NOCOPY NUMBER,
            x_tax_variance_account_id        OUT NOCOPY NUMBER,
            x_def_charges_account_id         OUT NOCOPY NUMBER,
            x_exchange_variance_account_id   OUT NOCOPY NUMBER,
            x_inv_variance_account_id        OUT NOCOPY NUMBER
	  );

PROCEDURE get_lock_handle (p_lock_name IN VARCHAR2, p_lock_handle IN OUT NOCOPY VARCHAR2);

END RCV_UTILITIES;

/
