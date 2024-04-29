--------------------------------------------------------
--  DDL for Package PN_VAR_ABATEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_ABATEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRABTS.pls 120.3 2007/07/02 15:20:28 lbala noship $ */

procedure INSERT_ROW (
  X_ROWID             in out NOCOPY VARCHAR2,
  X_VAR_ABATEMENT_ID  in out NOCOPY NUMBER,
  X_VAR_RENT_ID       in NUMBER,
  X_VAR_RENT_INV_ID   in NUMBER,
  X_PAYMENT_TERM_ID   in NUMBER,
  X_INCLUDE_TERM      in VARCHAR2,
  X_INCLUDE_INCREASES in VARCHAR2,
  X_UPDATE_FLAG       in VARCHAR2,
  X_CREATION_DATE     in DATE,
  X_CREATED_BY        in NUMBER,
  X_LAST_UPDATE_DATE  in DATE,
  X_LAST_UPDATED_BY   in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID            in NUMBER
  );

procedure LOCK_ROW (
  X_VAR_RENT_ID       in NUMBER,
  X_VAR_RENT_INV_ID   in NUMBER,
  X_PAYMENT_TERM_ID   in NUMBER
  );

procedure UPDATE_ROW (
  X_VAR_RENT_ID       in NUMBER,
  X_VAR_RENT_INV_ID   in NUMBER,
  X_PAYMENT_TERM_ID   in NUMBER,
  X_INCLUDE_TERM      in VARCHAR2,
  X_INCLUDE_INCREASES in VARCHAR2,
  X_UPDATE_FLAG       in VARCHAR2,
  X_LAST_UPDATE_DATE  in DATE,
  X_LAST_UPDATED_BY   in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
  );

procedure DELETE_ROW (
  X_VAR_RENT_ID       in NUMBER,
  X_VAR_RENT_INV_ID   in NUMBER,
  X_PAYMENT_TERM_ID   in NUMBER
  );

FUNCTION  CHECK_CALC_INV_EXISTS (
  p_var_rent_inv_id IN NUMBER,
  p_var_rent_id IN NUMBER
  )  RETURN VARCHAR2;

PROCEDURE ROLL_FWD_ON_UPD  (
  p_var_rentId IN NUMBER,
  p_var_rent_inv_id IN NUMBER,
  p_pmt_term_id IN NUMBER,
  flag IN NUMBER
  );

FUNCTION ABTMT_EXISTS (
  p_var_rentId IN NUMBER,
  p_var_rent_inv_id IN NUMBER,
  p_pmt_term_id IN NUMBER
  )  RETURN VARCHAR2;

PROCEDURE RESET_UPDATE_FLAG (
  p_var_rentId IN NUMBER,
  p_var_rent_inv_id IN NUMBER
  );

FUNCTION GET_INCLUDE_TERM(
  p_payment_term_id IN NUMBER,
  p_var_rent_inv_id IN NUMBER,
  p_var_rent_id IN NUMBER
  )
RETURN VARCHAR2;

FUNCTION GET_INCLUDE_INCREASES(
  p_payment_term_id IN NUMBER,
  p_var_rent_inv_id IN NUMBER,
  p_var_rent_id IN NUMBER
  )
RETURN VARCHAR2 ;

PROCEDURE ROLL_FWD_FST_ON_UPD(
  p_var_rentId IN NUMBER,
  p_var_rent_inv_id IN NUMBER,
  p_pmt_term_id IN NUMBER,
  flag IN NUMBER
  );

FUNCTION CHECK_TRUE_UP_INVOICE (p_var_rent_inv_id IN NUMBER)
RETURN  VARCHAR2 ;

end PN_VAR_ABATEMENTS_PKG;

/
