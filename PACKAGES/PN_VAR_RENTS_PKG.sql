--------------------------------------------------------
--  DDL for Package PN_VAR_RENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_RENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRENTS.pls 120.3 2007/01/30 04:05:48 piagrawa noship $ */

PROCEDURE INSERT_ROW (
  X_ROWID                       in out NOCOPY VARCHAR2,
  X_VAR_RENT_ID                 in out NOCOPY NUMBER,
  X_RENT_NUM                    in out NOCOPY VARCHAR2,
  X_LEASE_ID                    in NUMBER,
  X_LOCATION_ID                 in NUMBER,
  X_PRORATION_DAYS              in NUMBER,
  X_PURPOSE_CODE                in VARCHAR2,
  X_TYPE_CODE                   in VARCHAR2,
  X_COMMENCEMENT_DATE           in DATE,
  X_TERMINATION_DATE            in DATE,
  X_ABSTRACTED_BY_USER          in NUMBER,
  X_CUMULATIVE_VOL              in VARCHAR2,
  X_ACCRUAL                     in VARCHAR2,
  X_UOM_CODE                    in VARCHAR2,
  --X_ROUNDING                  in VARCHAR2,
  X_INVOICE_ON                  in VARCHAR2,
  X_NEGATIVE_RENT               in VARCHAR2,
  X_TERM_TEMPLATE_ID            in NUMBER,
 -- codev  X_ABATEMENT_AMOUNT            in NUMBER,
  X_ATTRIBUTE_CATEGORY          in VARCHAR2,
  X_ATTRIBUTE1                  in VARCHAR2,
  X_ATTRIBUTE2                  in VARCHAR2,
  X_ATTRIBUTE3                  in VARCHAR2,
  X_ATTRIBUTE4                  in VARCHAR2,
  X_ATTRIBUTE5                  in VARCHAR2,
  X_ATTRIBUTE6                  in VARCHAR2,
  X_ATTRIBUTE7                  in VARCHAR2,
  X_ATTRIBUTE8                  in VARCHAR2,
  X_ATTRIBUTE9                  in VARCHAR2,
  X_ATTRIBUTE10                 in VARCHAR2,
  X_ATTRIBUTE11                 in VARCHAR2,
  X_ATTRIBUTE12                 in VARCHAR2,
  X_ATTRIBUTE13                 in VARCHAR2,
  X_ATTRIBUTE14                 in VARCHAR2,
  X_ATTRIBUTE15                 in VARCHAR2,
  X_ORG_ID                      in NUMBER default NULL,
  X_CREATION_DATE               in DATE,
  X_CREATED_BY                  in NUMBER,
  X_LAST_UPDATE_DATE            in DATE,
  X_LAST_UPDATED_BY             in NUMBER,
  X_LAST_UPDATE_LOGIN           in NUMBER,
  X_CURRENCY_CODE               in VARCHAR2,
  X_AGREEMENT_TEMPLATE_ID       in NUMBER,
  X_PRORATION_RULE              in VARCHAR2,
  X_CHG_CAL_VAR_RENT_ID         in NUMBER
  );

PROCEDURE LOCK_ROW (
  X_VAR_RENT_ID                 in NUMBER,
  X_RENT_NUM                    in VARCHAR2,
  X_LEASE_ID                    in NUMBER,
  X_LOCATION_ID                 in NUMBER,
  X_PRORATION_DAYS              in NUMBER,
  X_PURPOSE_CODE                in VARCHAR2,
  X_TYPE_CODE                   in VARCHAR2,
  X_COMMENCEMENT_DATE           in DATE,
  X_TERMINATION_DATE            in DATE,
  X_ABSTRACTED_BY_USER          in NUMBER,
  X_CUMULATIVE_VOL              in VARCHAR2,
  X_ACCRUAL                     in VARCHAR2,
  X_UOM_CODE                    in VARCHAR2,
  --X_ROUNDING                  in VARCHAR2,
  X_INVOICE_ON                  in VARCHAR2,
  X_NEGATIVE_RENT               in VARCHAR2,
  X_TERM_TEMPLATE_ID            in NUMBER,
 -- codev  X_ABATEMENT_AMOUNT            in NUMBER,
  X_ATTRIBUTE_CATEGORY          in VARCHAR2,
  X_ATTRIBUTE1                  in VARCHAR2,
  X_ATTRIBUTE2                  in VARCHAR2,
  X_ATTRIBUTE3                  in VARCHAR2,
  X_ATTRIBUTE4                  in VARCHAR2,
  X_ATTRIBUTE5                  in VARCHAR2,
  X_ATTRIBUTE6                  in VARCHAR2,
  X_ATTRIBUTE7                  in VARCHAR2,
  X_ATTRIBUTE8                  in VARCHAR2,
  X_ATTRIBUTE9                  in VARCHAR2,
  X_ATTRIBUTE10                 in VARCHAR2,
  X_ATTRIBUTE11                 in VARCHAR2,
  X_ATTRIBUTE12                 in VARCHAR2,
  X_ATTRIBUTE13                 in VARCHAR2,
  X_ATTRIBUTE14                 in VARCHAR2,
  X_ATTRIBUTE15                 in VARCHAR2,
  X_CURRENCY_CODE               in VARCHAR2,
  X_AGREEMENT_TEMPLATE_ID       in NUMBER,
  X_PRORATION_RULE              in VARCHAR2,
  X_CHG_CAL_VAR_RENT_ID         in NUMBER
  );

PROCEDURE UPDATE_ROW (
  X_VAR_RENT_ID                 in NUMBER,
  X_RENT_NUM                    in VARCHAR2,
  X_LEASE_ID                    in NUMBER,
  X_LOCATION_ID                 in NUMBER,
  X_PRORATION_DAYS              in NUMBER,
  X_PURPOSE_CODE                in VARCHAR2,
  X_TYPE_CODE                   in VARCHAR2,
  X_COMMENCEMENT_DATE           in DATE,
  X_TERMINATION_DATE            in DATE,
  X_ABSTRACTED_BY_USER          in NUMBER,
  X_CUMULATIVE_VOL              in VARCHAR2,
  X_ACCRUAL                     in VARCHAR2,
  X_UOM_CODE                    in VARCHAR2,
  --X_ROUNDING                  in VARCHAR2,
  X_INVOICE_ON                  in VARCHAR2,
  X_NEGATIVE_RENT               in VARCHAR2,
  X_TERM_TEMPLATE_ID            in NUMBER,
-- codev  X_ABATEMENT_AMOUNT            in NUMBER,
  X_ATTRIBUTE_CATEGORY          in VARCHAR2,
  X_ATTRIBUTE1                  in VARCHAR2,
  X_ATTRIBUTE2                  in VARCHAR2,
  X_ATTRIBUTE3                  in VARCHAR2,
  X_ATTRIBUTE4                  in VARCHAR2,
  X_ATTRIBUTE5                  in VARCHAR2,
  X_ATTRIBUTE6                  in VARCHAR2,
  X_ATTRIBUTE7                  in VARCHAR2,
  X_ATTRIBUTE8                  in VARCHAR2,
  X_ATTRIBUTE9                  in VARCHAR2,
  X_ATTRIBUTE10                 in VARCHAR2,
  X_ATTRIBUTE11                 in VARCHAR2,
  X_ATTRIBUTE12                 in VARCHAR2,
  X_ATTRIBUTE13                 in VARCHAR2,
  X_ATTRIBUTE14                 in VARCHAR2,
  X_ATTRIBUTE15                 in VARCHAR2,
  X_LAST_UPDATE_DATE            in DATE,
  X_LAST_UPDATED_BY             in NUMBER,
  X_LAST_UPDATE_LOGIN           in NUMBER,
  X_CURRENCY_CODE               in VARCHAR2,
  X_AGREEMENT_TEMPLATE_ID       in NUMBER,
  X_PRORATION_RULE              in VARCHAR2,
  X_CHG_CAL_VAR_RENT_ID         in NUMBER
  );

PROCEDURE DELETE_ROW (
  X_VAR_RENT_ID                 in NUMBER
  );

------------------------------------------------------------------------
-- PROCEDURE : CHECK_UNIQUE_RENT_NUMBER
------------------------------------------------------------------------
PROCEDURE CHECK_UNIQUE_RENT_NUMBER
  (
  X_RETURN_STATUS               in out NOCOPY  VARCHAR2,
  X_VAR_RENT_ID                 in NUMBER,
  X_RENT_NUM                    in VARCHAR2,
  X_ORG_ID                      in NUMBER
  );

------------------------------------------------------------------------
-- PROCEDURE : CREATE_VAR_RENT_AGREEMENT
------------------------------------------------------------------------
Procedure create_var_rent_agreement
( p_pn_var_rents_rec IN pn_var_rents_all%rowtype DEFAULT NULL,
  p_var_rent_dates_rec IN pn_var_rent_dates_all%rowtype DEFAULT NULL,
  p_create_periods IN VARCHAR2 DEFAULT 'N',
  x_var_rent_id  OUT NOCOPY NUMBER,
  x_var_rent_num OUT NOCOPY VARCHAR2);

------------------------------------------------------------------------
-- PROCEDURE : MODIF_VAR_RENT
------------------------------------------------------------------------
PROCEDURE MODIF_VAR_RENT(x_var_rent_id IN NUMBER,
                         x_excess_abat_code IN VARCHAR2,
                         x_order_of_appl_code IN VARCHAR2) ;
------------------------------------------------------------------------
-- PROCEDURE : DELETE_VAR_RENT_AGREEMENT
------------------------------------------------------------------------
PROCEDURE DELETE_VAR_RENT_AGREEMENT(p_lease_id           IN NUMBER,
                                    p_termination_dt     IN DATE);

END PN_VAR_RENTS_PKG;

/
