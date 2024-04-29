--------------------------------------------------------
--  DDL for Package CSI_RESUBMIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_RESUBMIT_PUB" AUTHID CURRENT_USER AS
/* $Header: csiprshs.pls 115.6 2004/05/13 20:03:20 brmanesh ship $ */

  -- Default number of records fetch per call
  g_default_num_rec_fetch  NUMBER := 30;

  PROCEDURE resubmit_interface(
    errbuf        OUT NOCOPY  VARCHAR2,
    retcode       OUT NOCOPY  NUMBER,
    p_option      IN   VARCHAR2);

  PROCEDURE resubmit_waiting_txns(
    errbuf        OUT NOCOPY  VARCHAR2,
    retcode       OUT NOCOPY  NUMBER);

  PROCEDURE resubmit_error_txns(
    errbuf        OUT NOCOPY    VARCHAR2,
    retcode       OUT NOCOPY    NUMBER,
    process_flag  IN     VARCHAR2);

END csi_resubmit_pub;

 

/
