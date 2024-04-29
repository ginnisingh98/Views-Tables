--------------------------------------------------------
--  DDL for Package IGS_CO_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_SUBMIT" AUTHID CURRENT_USER AS
/* $Header: IGSCO21S.pls 120.1 2005/09/23 03:19:50 appldev ship $ */
PROCEDURE submit_correspondence_request (errbuf                          OUT NOCOPY VARCHAR2,
                                         retcode                         OUT NOCOPY NUMBER,
                                         p_map_id                        IN  NUMBER,
                                         p_select_type                   IN  VARCHAR2 ,
                                         p_list_id                       IN  NUMBER    DEFAULT NULL,
                                         p_person_id                     IN  NUMBER    DEFAULT NULL,
                                         p_override_flag                 IN  VARCHAR2  DEFAULT NULL,
                                         p_delivery_type                 IN  VARCHAR2  DEFAULT NULL,
					 p_destination                   IN  VARCHAR2  DEFAULT NULL, -- Added as part of bug# 2472250
					 p_dest_fax_number               IN  VARCHAR2  DEFAULT NULL,
					 p_reply_email                   IN  VARCHAR2  DEFAULT NULL,
					 p_sender_email                  IN  VARCHAR2  DEFAULT NULL,
					 p_cc_email                      IN  VARCHAR2  DEFAULT NULL,
                                         p_org_unit_id                   IN  NUMBER    DEFAULT NULL ,
                                         p_parameter_1                   IN  VARCHAR2  DEFAULT NULL,
                                         p_parameter_2                   IN  VARCHAR2  DEFAULT NULL,
                                         p_parameter_3                   IN  VARCHAR2  DEFAULT NULL,
                                         p_parameter_4                   IN  VARCHAR2  DEFAULT NULL,
                                         p_parameter_5                   IN  VARCHAR2  DEFAULT NULL,
                                         p_parameter_6                   IN  VARCHAR2  DEFAULT NULL,
                                         p_parameter_8                   IN  VARCHAR2  DEFAULT NULL,
                                         p_parameter_7                   IN  VARCHAR2  DEFAULT NULL,
                                         p_parameter_9                   IN  VARCHAR2  DEFAULT NULL,
                                         p_preview                       IN  VARCHAR2  DEFAULT NULL
                                       ) ;

PROCEDURE distribute_preview_request (errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER,
                                      p_distribution_id IN NUMBER
                                     );
END IGS_CO_SUBMIT;

 

/
