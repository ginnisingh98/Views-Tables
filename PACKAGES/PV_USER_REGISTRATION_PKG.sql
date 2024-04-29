--------------------------------------------------------
--  DDL for Package PV_USER_REGISTRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_USER_REGISTRATION_PKG" AUTHID CURRENT_USER as
/* $Header: pvregiss.pls 115.4 2002/12/11 10:24:12 anubhavk ship $ */


procedure notify_user_by_email(
                     p_creator            IN  VARCHAR2,
                     p_username           IN  VARCHAR2,
                     p_password           IN  VARCHAR2,
						   x_item_type          OUT NOCOPY VARCHAR2,
						   x_item_key           OUT NOCOPY VARCHAR2,
						   x_return_status      OUT NOCOPY VARCHAR2,
						   x_msg_count          OUT NOCOPY NUMBER,
						   x_msg_data           OUT NOCOPY VARCHAR2);

end pv_user_registration_pkg;

 

/
