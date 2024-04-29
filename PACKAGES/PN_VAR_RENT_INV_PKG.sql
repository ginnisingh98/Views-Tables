--------------------------------------------------------
--  DDL for Package PN_VAR_RENT_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_RENT_INV_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRINVS.pls 120.1 2006/12/20 07:32:56 rdonthul noship $ */


-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- HISTORY
--   18-AUG-06   Pikhar  o Added credit_flag,true_up_amount,true_up_status
--                         and true_up_exp_code
-------------------------------------------------------------------------------

procedure INSERT_ROW (
  X_ROWID                  in out NOCOPY VARCHAR2,
  X_VAR_RENT_INV_ID        in out NOCOPY NUMBER,
  X_ADJUST_NUM             in NUMBER,
  X_INVOICE_DATE           in DATE,
  X_FOR_PER_RENT           in NUMBER,
  X_TOT_ACT_VOL            in NUMBER,
  X_ACT_PER_RENT           in NUMBER,
  X_CONSTR_ACTUAL_RENT     in NUMBER,
  X_ABATEMENT_APPL         in NUMBER,
  X_REC_ABATEMENT          in NUMBER,
  X_REC_ABATEMENT_OVERRIDE in NUMBER,
  X_NEGATIVE_RENT          in NUMBER,
  X_ACTUAL_INVOICED_AMOUNT in NUMBER,
  X_PERIOD_ID              in NUMBER,
  X_VAR_RENT_ID            in NUMBER,
  X_FORECASTED_TERM_STATUS in VARCHAR2,
  X_VARIANCE_TERM_STATUS   in VARCHAR2,
  X_ACTUAL_TERM_STATUS     in VARCHAR2,
  X_FORECASTED_EXP_CODE    in VARCHAR2,
  X_VARIANCE_EXP_CODE      in VARCHAR2,
  X_ACTUAL_EXP_CODE        in VARCHAR2,
  X_COMMENTS               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY     in VARCHAR2,
  X_ATTRIBUTE1             in VARCHAR2,
  X_ATTRIBUTE2             in VARCHAR2,
  X_ATTRIBUTE3             in VARCHAR2,
  X_ATTRIBUTE4             in VARCHAR2,
  X_ATTRIBUTE5             in VARCHAR2,
  X_ATTRIBUTE6             in VARCHAR2,
  X_ATTRIBUTE7             in VARCHAR2,
  X_ATTRIBUTE8             in VARCHAR2,
  X_ATTRIBUTE9             in VARCHAR2,
  X_ATTRIBUTE10            in VARCHAR2,
  X_ATTRIBUTE11            in VARCHAR2,
  X_ATTRIBUTE12            in VARCHAR2,
  X_ATTRIBUTE13            in VARCHAR2,
  X_ATTRIBUTE14            in VARCHAR2,
  X_ATTRIBUTE15            in VARCHAR2,
  X_CREATION_DATE          in DATE,
  X_CREATED_BY             in NUMBER,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER,
  X_ORG_ID                 in NUMBER,
  X_CREDIT_FLAG            in VARCHAR2 DEFAULT 'N',
  X_TRUE_UP_AMOUNT         in NUMBER DEFAULT NULL,
  X_TRUE_UP_STATUS         in VARCHAR2 DEFAULT NULL,
  X_TRUE_UP_EXP_CODE       in VARCHAR2 DEFAULT NULL);



-----------------------------------------------------------------------
---- PROCEDURE : LOCK_ROW_EXCEPTION
-----------------------------------------------------------------------

procedure lock_row_exception (p_column_name in varchar2,
                              p_new_value   in varchar2);


-----------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-----------------------------------------------------------------------

procedure LOCK_ROW (
  X_VAR_RENT_INV_ID        in NUMBER,
  X_ADJUST_NUM             in NUMBER,
  X_INVOICE_DATE           in DATE,
  X_FOR_PER_RENT           in NUMBER,
  X_TOT_ACT_VOL            in NUMBER,
  X_ACT_PER_RENT           in NUMBER,
  X_CONSTR_ACTUAL_RENT     in NUMBER,
  X_ABATEMENT_APPL         in NUMBER,
  X_REC_ABATEMENT          in NUMBER,
  X_REC_ABATEMENT_OVERRIDE in NUMBER,
  X_NEGATIVE_RENT          in NUMBER,
  X_ACTUAL_INVOICED_AMOUNT in NUMBER,
  X_PERIOD_ID              in NUMBER,
  X_VAR_RENT_ID            in NUMBER,
  X_FORECASTED_TERM_STATUS in VARCHAR2,
  X_VARIANCE_TERM_STATUS   in VARCHAR2,
  X_ACTUAL_TERM_STATUS     in VARCHAR2,
  X_FORECASTED_EXP_CODE    in VARCHAR2,
  X_VARIANCE_EXP_CODE      in VARCHAR2,
  X_ACTUAL_EXP_CODE        in VARCHAR2,
  X_COMMENTS               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY     in VARCHAR2,
  X_ATTRIBUTE1             in VARCHAR2,
  X_ATTRIBUTE2             in VARCHAR2,
  X_ATTRIBUTE3             in VARCHAR2,
  X_ATTRIBUTE4             in VARCHAR2,
  X_ATTRIBUTE5             in VARCHAR2,
  X_ATTRIBUTE6             in VARCHAR2,
  X_ATTRIBUTE7             in VARCHAR2,
  X_ATTRIBUTE8             in VARCHAR2,
  X_ATTRIBUTE9             in VARCHAR2,
  X_ATTRIBUTE10            in VARCHAR2,
  X_ATTRIBUTE11            in VARCHAR2,
  X_ATTRIBUTE12            in VARCHAR2,
  X_ATTRIBUTE13            in VARCHAR2,
  X_ATTRIBUTE14            in VARCHAR2,
  X_ATTRIBUTE15            in VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
-----------------------------------------------------------------------


procedure UPDATE_ROW (
  X_VAR_RENT_INV_ID        in NUMBER,
  X_ADJUST_NUM             in NUMBER,
  X_INVOICE_DATE           in DATE,
  X_FOR_PER_RENT           in NUMBER,
  X_TOT_ACT_VOL            in NUMBER,
  X_ACT_PER_RENT           in NUMBER,
  X_CONSTR_ACTUAL_RENT     in NUMBER,
  X_ABATEMENT_APPL         in NUMBER,
  X_REC_ABATEMENT          in NUMBER,
  X_REC_ABATEMENT_OVERRIDE in NUMBER,
  X_NEGATIVE_RENT          in NUMBER,
  X_ACTUAL_INVOICED_AMOUNT in NUMBER,
  X_PERIOD_ID              in NUMBER,
  X_VAR_RENT_ID            in NUMBER,
  X_FORECASTED_TERM_STATUS in VARCHAR2,
  X_VARIANCE_TERM_STATUS   in VARCHAR2,
  X_ACTUAL_TERM_STATUS     in VARCHAR2,
  X_FORECASTED_EXP_CODE    in VARCHAR2,
  X_VARIANCE_EXP_CODE      in VARCHAR2,
  X_ACTUAL_EXP_CODE        in VARCHAR2,
  X_COMMENTS               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY     in VARCHAR2,
  X_ATTRIBUTE1             in VARCHAR2,
  X_ATTRIBUTE2             in VARCHAR2,
  X_ATTRIBUTE3             in VARCHAR2,
  X_ATTRIBUTE4             in VARCHAR2,
  X_ATTRIBUTE5             in VARCHAR2,
  X_ATTRIBUTE6             in VARCHAR2,
  X_ATTRIBUTE7             in VARCHAR2,
  X_ATTRIBUTE8             in VARCHAR2,
  X_ATTRIBUTE9             in VARCHAR2,
  X_ATTRIBUTE10            in VARCHAR2,
  X_ATTRIBUTE11            in VARCHAR2,
  X_ATTRIBUTE12            in VARCHAR2,
  X_ATTRIBUTE13            in VARCHAR2,
  X_ATTRIBUTE14            in VARCHAR2,
  X_ATTRIBUTE15            in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER
);

-----------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-----------------------------------------------------------------------

procedure DELETE_ROW (
  X_VAR_RENT_INV_ID in NUMBER
);

END PN_VAR_RENT_INV_PKG;


/
