--------------------------------------------------------
--  DDL for Package FUN_NET_CANCEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_NET_CANCEL_PKG" AUTHID CURRENT_USER AS
/* $Header: funntcrs.pls 120.1.12010000.2 2008/08/06 07:46:53 makansal ship $ */

PROCEDURE get_batch_status(
           p_batch_id      IN fun_net_batches_all.batch_id%TYPE,
           x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Batch_Status
                (p_mode          IN VARCHAR2,
                 p_batch_id      IN fun_net_batches.batch_id%TYPE,
                 x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE delete_ap_invs (
                p_batch_id      IN fun_net_batches.batch_id%TYPE,
                x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE delete_ar_txns (
                x_batch_id      IN fun_net_batches.batch_id%TYPE,
                x_return_status OUT NOCOPY VARCHAR2);

 PROCEDURE cancel_net_batch(
            -- ***** Standard API Parameters *****
            p_init_msg_list IN VARCHAR2 := FND_API.G_TRUE,
            p_commit        IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id      IN NUMBER);

 PROCEDURE reverse_net_batch(
            -- ***** Standard API Parameters *****
            p_init_msg_list IN VARCHAR2 := FND_API.G_TRUE,
            p_commit        IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id      IN NUMBER);
END FUN_NET_CANCEL_PKG; -- Package spec

/
