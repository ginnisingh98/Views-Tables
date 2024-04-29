--------------------------------------------------------
--  DDL for Package MSC_SRP_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SRP_RELEASE" AUTHID CURRENT_USER AS
/* $Header: MSCPSRPS.pls 120.2 2007/07/16 05:43:05 vpalla noship $ */
IRO_LOAD                CONSTANT  NUMBER := 256;

PROCEDURE log_message( p_user_info IN VARCHAR2);

PROCEDURE MSC_RELEASE_IRO( p_user_name        IN  VARCHAR2,
                           p_resp_name        IN  VARCHAR2,
                           p_application_name IN  VARCHAR2,
                           p_application_id   IN  NUMBER,
                           p_batch_id    IN        number,
                           p_load_type   IN        number,
                           arg_iro_load_id           IN OUT  NOCOPY  Number
                        );
Procedure  Release_new_IRO (
                                   errbuf        OUT NOCOPY VARCHAR2,
                                   retcode       OUT NOCOPY VARCHAR2,
                                   p_batch_id    IN  number);

	PROCEDURE  Release_new_ERO (      errbuf        OUT NOCOPY VARCHAR2,
                                   retcode       OUT NOCOPY VARCHAR2,
                                   p_batch_id    IN  number);
END MSC_SRP_RELEASE;

/
