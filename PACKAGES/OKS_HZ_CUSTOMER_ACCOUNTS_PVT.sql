--------------------------------------------------------
--  DDL for Package OKS_HZ_CUSTOMER_ACCOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_HZ_CUSTOMER_ACCOUNTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSCOTS.pls 120.1 2005/09/08 04:45:17 hkamdar noship $ */
  ---------------------------------------------------------------------------
  procedure init (p_account_rec     OUT NOCOPY hz_cust_account_v2pub.cust_account_rec_type,
		        p_cust_prof_rec  OUT NOCOPY hz_customer_profile_v2pub.customer_profile_rec_type);

  procedure UPDATE_ROW (p_cust_account_id in number,
                        p_coterm_day_month in varchar2);
END OKS_HZ_CUSTOMER_ACCOUNTS_PVT ;

 

/
