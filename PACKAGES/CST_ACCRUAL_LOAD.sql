--------------------------------------------------------
--  DDL for Package CST_ACCRUAL_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_ACCRUAL_LOAD" AUTHID CURRENT_USER as
/* $Header: CSTACCLS.pls 120.0.12010000.2 2008/10/29 12:23:28 smsasidh ship $ */

PROCEDURE Start_accrual_load(errbuf           OUT  NOCOPY VARCHAR2,
                             retcode          OUT  NOCOPY NUMBER,
                             p_from_date      IN   VARCHAR2,
                             p_to_date        IN   VARCHAR2
                            );

PROCEDURE accrual_load(p_api_version    IN  NUMBER,
                       p_init_msg_list  IN  VARCHAR2,
                       p_commit         IN  VARCHAR2,
                       p_operating_unit IN  NUMBER,
                       p_from_date      IN  VARCHAR2,
                       p_to_date        IN  VARCHAR2,
                       x_return_status  OUT NOCOPY VARCHAR2,
                       x_msg_count      OUT NOCOPY NUMBER,
                       x_msg_data       OUT NOCOPY VARCHAR2
                       );

PROCEDURE upgrade_old_data(p_operating_unit  IN  NUMBER,
                          -- HYU: New Parameters
                           p_upg_from_date   IN DATE,
                           p_upg_to_date     IN DATE,
                           --
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2);

Procedure Load_ap_misc_data(p_operating_unit   IN NUMBER,
                            p_from_date        IN DATE,
                            p_to_date          IN DATE,
                            p_round_unit       IN NUMBER,
                            x_msg_count       OUT NOCOPY NUMBER,
                            x_msg_data        OUT NOCOPY VARCHAR2,
                            x_return_status   OUT NOCOPY VARCHAR2
                            );

Procedure Load_inv_misc_data(p_operating_unit  IN NUMBER,
                             p_from_date       IN DATE,
                             p_to_date         IN DATE,
                             p_round_unit      IN NUMBER,
                             x_msg_count       OUT NOCOPY NUMBER,
                             x_msg_data        OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2
                             );

Procedure Insert_build_parameters(p_operating_unit IN NUMBER,
                                  p_from_date      IN DATE,
                                  p_to_date        IN DATE,
                                  x_msg_count       OUT NOCOPY NUMBER,
                                  x_msg_data        OUT NOCOPY VARCHAR2,
                                  x_return_status   OUT NOCOPY VARCHAR2
                                  );

Procedure Load_ap_po_data(p_operating_unit  IN  VARCHAR2,
                          p_from_date       IN  DATE,
                          p_to_date         IN  DATE,
                          p_round_unit      IN  NUMBER,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2
                          );

END CST_ACCRUAL_LOAD;

/
