--------------------------------------------------------
--  DDL for Package AR_INTEREST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INTEREST_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARIILINES.pls 120.1.12010000.3 2009/04/08 11:05:11 pbapna ship $ */

PROCEDURE Lock_line
(P_INTEREST_LINE_ID        IN  NUMBER,
 P_INTEREST_HEADER_ID      IN  NUMBER,
 P_PAYMENT_SCHEDULE_ID     IN  NUMBER,
 P_TYPE                    IN  VARCHAR2,
 P_ORIGINAL_TRX_CLASS      IN  VARCHAR2,
 P_DAILY_INTEREST_CHARGE   IN  NUMBER,
 P_OUTSTANDING_AMOUNT      IN  NUMBER,
 P_DAYS_OVERDUE_LATE       IN  NUMBER,
 P_DAYS_OF_INTEREST        IN  NUMBER,
 P_INTEREST_CHARGED        IN  NUMBER,
 P_PAYMENT_DATE            IN  DATE,
 P_FINANCE_CHARGE_CHARGED  IN  NUMBER,
 P_AMOUNT_DUE_ORIGINAL     IN  NUMBER,
 P_AMOUNT_DUE_REMAINING    IN  NUMBER,
 P_ORIGINAL_TRX_ID         IN  NUMBER,
 P_RECEIVABLES_TRX_ID      IN  NUMBER,
 P_LAST_CHARGE_DATE        IN  DATE,
 P_DUE_DATE                IN  DATE,
 P_ACTUAL_DATE_CLOSED      IN  DATE,
 P_INTEREST_RATE           IN  NUMBER,
 P_RATE_START_DATE         IN  DATE,
 P_RATE_END_DATE           IN  DATE,
 P_SCHEDULE_DAYS_FROM      IN  NUMBER,
 P_SCHEDULE_DAYS_TO        IN  NUMBER,
 P_LAST_UPDATE_DATE        IN  DATE,
 P_LAST_UPDATED_BY         IN  NUMBER,
 P_LAST_UPDATE_LOGIN       IN  NUMBER,
 P_PROCESS_STATUS          IN  VARCHAR2,
 P_PROCESS_MESSAGE         IN  VARCHAR2,
 P_ORG_ID                  IN  NUMBER,
 P_OBJECT_VERSION_NUMBER   IN  NUMBER,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2);




PROCEDURE validate_line
(p_action                 IN VARCHAR2,
 p_old_rec                IN ar_interest_lines%ROWTYPE,
 p_new_rec                IN ar_interest_lines%ROWTYPE,
 x_return_status      IN OUT NOCOPY VARCHAR2);


PROCEDURE Update_line
(p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false,
 P_INTEREST_LINE_ID       IN NUMBER,
 P_PROCESS_STATUS         IN VARCHAR2,
 P_PROCESS_MESSAGE        IN VARCHAR2,
 x_object_version_number  IN OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_count              OUT NOCOPY    NUMBER,
 x_msg_data               OUT NOCOPY    VARCHAR2,
 P_DAYS_INTEREST          IN NUMBER Default NULL,
 P_INTEREST_CHARGED       IN NUMBER Default NULL);

PROCEDURE Delete_line
(p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false,
 p_interest_line_id       IN NUMBER,
 x_object_version_number  IN NUMBER,
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_count              OUT NOCOPY    NUMBER,
 x_msg_data               OUT NOCOPY    VARCHAR2);

END AR_INTEREST_LINES_PKG;

/
