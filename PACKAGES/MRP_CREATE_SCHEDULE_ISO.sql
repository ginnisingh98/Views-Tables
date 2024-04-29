--------------------------------------------------------
--  DDL for Package MRP_CREATE_SCHEDULE_ISO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_CREATE_SCHEDULE_ISO" AUTHID CURRENT_USER AS
/* $Header: MRPCISOS.pls 120.1 2007/04/27 07:04:08 vpalla ship $ */

-- CONSTANTS --
    DRP_REQ_LOAD            constant integer := 32;
    DRP_REQ_RESCHED         constant integer := 64;



-- Procedures --
PROCEDURE log_message( p_user_info IN VARCHAR2);

PROCEDURE MSC_RELEASE_ISO( p_batch_id    IN        number,
                           p_load_type   IN        number,
                           arg_int_req_load_id           IN OUT  NOCOPY  Number,
                           arg_int_req_resched_id        IN OUT  NOCOPY  Number );

PROCEDURE CREATE_AND_SCHEDULE_ISO(
                                   errbuf        OUT NOCOPY VARCHAR2,
                                   retcode       OUT NOCOPY VARCHAR2,
                                   p_batch_id    IN  number);

PROCEDURE Create_IR_ISO(           errbuf                OUT NOCOPY VARCHAR2,
                                   retcode               OUT NOCOPY VARCHAR2,
                                   p_Ireq_header_id      OUT NOCOPY number,
                                   p_ISO_header_id       OUT NOCOPY number,
                                   p_Transaction_id      IN  number,
                                   p_batch_id            IN  number) ;

END MRP_CREATE_SCHEDULE_ISO;

/
