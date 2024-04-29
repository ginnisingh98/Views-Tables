--------------------------------------------------------
--  DDL for Package IGS_FI_SS_CHARGES_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_SS_CHARGES_API_PVT" AUTHID CURRENT_USER AS
/* $Header: IGSFI71S.pls 120.1 2005/09/11 21:31:52 appldev ship $ */
/* CHANGE HISTORY:
  WHO        WHEN         WHAT
  svuppala  09-Sep-2005  Enh#4506599 Added x_waiver_amount as OUT parameter
  vvutukur  23-Sep-2002  Enh#2564643.Removed reference to subaccount_id from parameter list of
                         create_charge procedure.
*/

PROCEDURE create_charge(
                        p_api_version                    IN  NUMBER,
                        p_init_msg_list                  IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
                        p_commit                         IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
                        p_validation_level               IN  NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
                        p_person_id                      IN  NUMBER,
                        p_fee_type                       IN  VARCHAR2,
                        p_fee_cat                        IN  VARCHAR2,
                        p_fee_cal_type                   IN  VARCHAR2,
                        p_fee_ci_sequence_number         IN  NUMBER,
                        p_course_cd                      IN  VARCHAR2,
                        p_attendance_type                IN  VARCHAR2,
                        p_attendance_mode                IN  VARCHAR2,
                        p_invoice_amount                 IN  NUMBER,
                        p_invoice_creation_date          IN  DATE,
                        p_invoice_desc                   IN  VARCHAR2,
                        p_transaction_type               IN  VARCHAR2,
                        p_currency_cd                    IN  VARCHAR2,
                        p_exchange_rate                  IN  NUMBER,
                        p_effective_date                 IN  DATE,
                        p_waiver_flag                    IN  VARCHAR2,
                        p_waiver_reason                  IN  VARCHAR2,
                        p_source_transaction_id          IN  NUMBER,
                        p_invoice_id                    OUT NOCOPY  NUMBER,
                        x_return_status                 OUT NOCOPY  VARCHAR2,
                        x_msg_count                     OUT NOCOPY  NUMBER,
                        x_msg_data                      OUT NOCOPY  VARCHAR2,
                        x_waiver_amount                 OUT NOCOPY  NUMBER
                       );

END IGS_FI_SS_CHARGES_API_PVT;

 

/
