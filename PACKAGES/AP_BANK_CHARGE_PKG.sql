--------------------------------------------------------
--  DDL for Package AP_BANK_CHARGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_BANK_CHARGE_PKG" AUTHID CURRENT_USER AS
/* $Header: apsudbcs.pls 120.4 2006/09/27 07:47:32 bghose noship $ */

PROCEDURE get_bank_number(
	P_bank_name		IN	VARCHAR2,
	P_bank_number		IN OUT NOCOPY	VARCHAR2);

PROCEDURE get_bank_branch_name(
        P_bank_branch_id        IN      NUMBER,
	P_bank_number		IN OUT NOCOPY	VARCHAR2,
	P_branch_number		IN OUT NOCOPY	VARCHAR2,
        P_branch_name           IN OUT NOCOPY     VARCHAR2);

PROCEDURE CHECK_BANK_COMBINATION(
                P_transferring_bank_branch_id   IN      NUMBER,
                P_transferring_bank_name        IN      VARCHAR2,
                P_transferring_bank             IN      VARCHAR2,
                P_transferring_branch           IN      VARCHAR2,
                P_receiving_bank_branch_id      IN      NUMBER,
                P_receiving_bank_name           IN      VARCHAR2,
                P_receiving_bank                IN      VARCHAR2,
                P_receiving_branch              IN      VARCHAR2,
                P_transfer_priority             IN      VARCHAR2,
                P_currency_code                 IN      VARCHAR2);

PROCEDURE CHECK_RANGE_OVERLAP(
                X_bank_charge_id        IN      NUMBER);

PROCEDURE CHECK_RANGE_GAP(
		X_bank_charge_id 	IN	NUMBER);

PROCEDURE CHECK_LAST_RANGE(
		X_bank_charge_id 	IN	NUMBER);

PROCEDURE GET_BANK_CHARGE(
                P_bank_charge_bearer            IN      VARCHAR2,
                P_transferring_bank_branch_id   IN      NUMBER,
                P_receiving_bank_branch_id      IN      NUMBER,
                P_transfer_priority             IN      VARCHAR2,
                P_currency_code                 IN      VARCHAR2,
                P_transaction_amount            IN      NUMBER,
                P_transaction_date              IN      DATE,
                P_bank_charge_standard          OUT NOCOPY  NUMBER,
                P_bank_charge_negotiated        OUT NOCOPY  NUMBER,
                P_calc_bank_charge_standard     OUT NOCOPY  NUMBER,
                P_calc_bank_charge_negotiated   OUT NOCOPY  NUMBER,
                P_tolerance_limit               OUT NOCOPY  NUMBER);

PROCEDURE CHECK_BANK_CHARGE(
                P_bank_charge_bearer            IN      VARCHAR2,
                P_transferring_bank_branch_id   IN      NUMBER,
                P_receiving_bank_branch_id      IN      NUMBER,
                P_transfer_priority             IN      VARCHAR2,
                P_currency_code                 IN      VARCHAR2,
                P_transaction_amount            IN      NUMBER,
                P_transaction_date              IN      DATE,
                P_check_bc_flag                 OUT NOCOPY     VARCHAR2,
                P_do_not_pay_reason             OUT NOCOPY     VARCHAR2);

PROCEDURE ap_JapanBankChargeHook(
                p_api_version    IN  NUMBER,
                p_init_msg_list  IN  VARCHAR2,
                p_commit         IN  VARCHAR2,
                x_return_status  OUT nocopy VARCHAR2,
                x_msg_count      OUT nocopy NUMBER,
                x_msg_data       OUT nocopy VARCHAR2);



END AP_BANK_CHARGE_PKG;

 

/
