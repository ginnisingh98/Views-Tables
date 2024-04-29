--------------------------------------------------------
--  DDL for Package ONT_ICP_GET_USER_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_ICP_GET_USER_DETAILS" AUTHID CURRENT_USER as
/*$Header: OEXONTHS.pls 120.0 2005/06/01 03:06:32 appldev noship $ */

  procedure get_user_customer(in_user          IN NUMBER,
out_name OUT NOCOPY VARCHAR2,

out_customer OUT NOCOPY VARCHAR2,

out_customer_id OUT NOCOPY NUMBER,

out_contact_id OUT NOCOPY NUMBER,

out_status OUT NOCOPY VARCHAR2

					    );

end ONT_icp_get_user_details; /* end of package spec */

 

/
