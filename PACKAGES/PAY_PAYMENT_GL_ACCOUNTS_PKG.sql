--------------------------------------------------------
--  DDL for Package PAY_PAYMENT_GL_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYMENT_GL_ACCOUNTS_PKG" AUTHID CURRENT_USER as
/* $Header: pypga01t.pkh 120.0 2005/09/29 10:52 tvankayl noship $ */

procedure INSERT_ROW (
  P_PAY_GL_ACCOUNT_ID OUT NOCOPY NUMBER,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_GL_CASH_AC_ID in NUMBER,
  P_GL_CASH_CLEARING_AC_ID in NUMBER,
  P_GL_CONTROL_AC_ID in NUMBER,
  P_GL_ERROR_AC_ID in NUMBER,
  P_EXTERNAL_ACCOUNT_ID in NUMBER,
  P_ORG_PAYMENT_METHOD_ID in NUMBER,
  P_DEFAULT_GL_ACCOUNT in VARCHAR2);

procedure UPDATE_ROW (
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_GL_CASH_AC_ID in NUMBER,
  P_GL_CASH_CLEARING_AC_ID in NUMBER,
  P_GL_CONTROL_AC_ID in NUMBER,
  P_GL_ERROR_AC_ID in NUMBER,
  P_EXTERNAL_ACCOUNT_ID in NUMBER,
  P_ORG_PAYMENT_METHOD_ID in NUMBER,
  P_DT_UPDATE_MODE in VARCHAR2,
  P_DEFAULT_GL_ACCOUNT  in VARCHAR2,
  P_PAY_GL_ACCOUNT_ID_OUT  OUT NOCOPY NUMBER  );


procedure DELETE_ROW (
  p_org_payment_method_id in NUMBER
 ,p_effective_date      in  DATE
 ,p_datetrack_mode      in  VARCHAR2
 ,p_org_eff_start_date  in  DATE
 ,p_org_eff_end_date    in  DATE );


function DEFAULT_GL_ACCOUNTS (
  P_EXTERNAL_ACCOUNT_ID in NUMBER)
RETURN NUMBER ;

function OPM_GL_ACCOUNTS (
  P_ORG_PAYMENT_METHOD_ID in NUMBER)
RETURN NUMBER ;

procedure GET_GL_ACCOUNTS
    ( p_pay_gl_account_id in number,
      p_effective_date in date ,
      p_set_of_books_id out NOCOPY number,
      p_set_of_books_name out NOCOPY varchar2,
      p_gl_account_flex_num out NOCOPY number,
      p_gl_cash_ac_id out NOCOPY number,
      p_gl_cash_clearing_ac_id out NOCOPY number,
      p_gl_control_ac_id out NOCOPY number,
      p_gl_error_ac_id out NOCOPY number
    );

end PAY_PAYMENT_GL_ACCOUNTS_PKG;


 

/
