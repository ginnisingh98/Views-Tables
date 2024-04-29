--------------------------------------------------------
--  DDL for Package QA_ERES_SHIPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_ERES_SHIPPING" AUTHID CURRENT_USER AS
/* $Header: qaerwshs.pls 115.0 2003/10/18 00:44:01 isivakum noship $ */

  g_event_name_const CONSTANT VARCHAR2(240) :=
                 'oracle.apps.wsh.eres.delivery.shipment';

  PROCEDURE wrapper(ERRBUF    OUT NOCOPY VARCHAR2,
                    RETCODE   OUT NOCOPY NUMBER,
                    ARGUMENT1 IN         VARCHAR2,
                    ARGUMENT2 IN         VARCHAR2);


  PROCEDURE delivery_erecord(p_from_date  IN  DATE,
                             p_to_date    IN  DATE,
                             x_status OUT NOCOPY VARCHAR2);

  PROCEDURE raise_delivery_event(p_delivery_id  IN  NUMBER,
                                 p_delivery_name   IN  VARCHAR2 DEFAULT NULL,
				                 p_erecord_id OUT NOCOPY NUMBER,
				                 x_status OUT NOCOPY VARCHAR2);


END qa_eres_shipping;


 

/
