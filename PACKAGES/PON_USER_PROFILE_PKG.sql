--------------------------------------------------------
--  DDL for Package PON_USER_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_USER_PROFILE_PKG" AUTHID CURRENT_USER as
/*$Header: PONUSPRS.pls 120.5 2006/03/31 05:50:28 rpatel noship $ */

--This ref cursor type is used for any cursors we need to pass out
--to Java.  Namely addresses and all the subset preference stuff:
--payment methods, credit card types, payment terms, carrier,
--freight terms, fob.
type refCurTyp is Ref Cursor;

UPDATE_SUPPLIER_CONTACT_E EXCEPTION;


procedure update_user_lang(
  p_username        IN VARCHAR2
, p_user_language   IN VARCHAR2
, x_status          OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
);

procedure update_user_info(
  p_username                        IN VARCHAR2
, P_USER_NAME_PREFIX                IN VARCHAR2
, P_USER_NAME_F                             IN VARCHAR2
, P_USER_NAME_M                             IN VARCHAR2
, P_USER_NAME_L                             IN VARCHAR2
, P_USER_NAME_SUFFIX                IN VARCHAR2
, P_USER_TITLE                              IN VARCHAR2
, P_USER_EMAIL                              IN VARCHAR2
, P_USER_COUNTRY_CODE               IN VARCHAR2
, P_USER_AREA_CODE                  IN VARCHAR2
, P_USER_PHONE                              IN VARCHAR2
, P_USER_EXTENSION                  IN VARCHAR2
, P_USER_FAX_COUNTRY_CODE   IN VARCHAR2
, P_USER_FAX_AREA_CODE              IN VARCHAR2
, P_USER_FAX                                IN VARCHAR2
, P_USER_FAX_EXTENSION              IN VARCHAR2
, P_USER_TIMEZONE                   IN VARCHAR2
, P_USER_LANGUAGE                   IN VARCHAR2
, P_USER_DATEFORMAT                   IN VARCHAR2
, P_USER_LOCALE        IN VARCHAR2
, P_USER_ENCODINGOPTION	IN VARCHAR2
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
);


procedure retrieve_vendor_user_info(
  p_username                        IN VARCHAR2
, x_user_party_id                   OUT NOCOPY NUMBER
, X_USER_NAME_PREFIX                OUT NOCOPY VARCHAR2
, X_USER_NAME_F                     OUT NOCOPY VARCHAR2
, X_USER_NAME_M                     OUT NOCOPY VARCHAR2
, X_USER_NAME_L                     OUT NOCOPY VARCHAR2
, X_USER_NAME_SUFFIX                OUT NOCOPY VARCHAR2
, X_USER_TITLE                      OUT NOCOPY VARCHAR2
, X_USER_EMAIL                      OUT NOCOPY VARCHAR2
, X_USER_COUNTRY_CODE               OUT NOCOPY VARCHAR2
, X_USER_AREA_CODE                  OUT NOCOPY VARCHAR2
, X_USER_PHONE                      OUT NOCOPY VARCHAR2
, X_USER_EXTENSION                  OUT NOCOPY VARCHAR2
, X_USER_FAX_COUNTRY_CODE           OUT NOCOPY VARCHAR2
, X_USER_FAX_AREA_CODE              OUT NOCOPY VARCHAR2
, X_USER_FAX                        OUT NOCOPY VARCHAR2
, X_USER_FAX_EXTENSION              OUT NOCOPY VARCHAR2
, X_USER_ENCODINGOPTION              OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
);

procedure retrieve_enterprise_user_info(
  p_username                        IN VARCHAR2
, x_user_party_id                   OUT NOCOPY NUMBER
, X_USER_NAME_PREFIX                OUT NOCOPY VARCHAR2
, X_USER_NAME_F                     OUT NOCOPY VARCHAR2
, X_USER_NAME_M                     OUT NOCOPY VARCHAR2
, X_USER_NAME_L                     OUT NOCOPY VARCHAR2
, X_USER_NAME_SUFFIX                OUT NOCOPY VARCHAR2
, X_USER_TITLE                      OUT NOCOPY VARCHAR2
, X_USER_EMAIL                      OUT NOCOPY VARCHAR2
, X_USER_COUNTRY_CODE               OUT NOCOPY VARCHAR2
, X_USER_AREA_CODE                  OUT NOCOPY VARCHAR2
, X_USER_PHONE                      OUT NOCOPY VARCHAR2
, X_USER_EXTENSION                  OUT NOCOPY VARCHAR2
, X_USER_FAX_COUNTRY_CODE           OUT NOCOPY VARCHAR2
, X_USER_FAX_AREA_CODE              OUT NOCOPY VARCHAR2
, X_USER_FAX                        OUT NOCOPY VARCHAR2
, X_USER_FAX_EXTENSION              OUT NOCOPY VARCHAR2
, X_USER_ENCODINGOPTION              OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
);

procedure retrieve_user_info(
  p_username                        IN VARCHAR2
, x_user_party_id                   OUT NOCOPY NUMBER
, X_USER_NAME_PREFIX                OUT NOCOPY VARCHAR2
, X_USER_NAME_F                     OUT NOCOPY VARCHAR2
, X_USER_NAME_M                     OUT NOCOPY VARCHAR2
, X_USER_NAME_L                     OUT NOCOPY VARCHAR2
, X_USER_NAME_SUFFIX                OUT NOCOPY VARCHAR2
, X_USER_TITLE                      OUT NOCOPY VARCHAR2
, X_USER_EMAIL                      OUT NOCOPY VARCHAR2
, X_USER_COUNTRY_CODE               OUT NOCOPY VARCHAR2
, X_USER_AREA_CODE                  OUT NOCOPY VARCHAR2
, X_USER_PHONE                      OUT NOCOPY VARCHAR2
, X_USER_EXTENSION                  OUT NOCOPY VARCHAR2
, X_USER_FAX_COUNTRY_CODE           OUT NOCOPY VARCHAR2
, X_USER_FAX_AREA_CODE              OUT NOCOPY VARCHAR2
, X_USER_FAX                        OUT NOCOPY VARCHAR2
, X_USER_FAX_EXTENSION              OUT NOCOPY VARCHAR2
, X_USER_TIMEZONE                   OUT NOCOPY VARCHAR2
, X_USER_DEFAULT_LANGUAGE           OUT NOCOPY VARCHAR2
, X_USER_DEFAULT_DATEFORMAT           OUT NOCOPY VARCHAR2
, X_USER_LOCALE                   OUT NOCOPY VARCHAR2
, X_USER_ENCODINGOPTION              OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
);

procedure change_password(
  p_username     IN VARCHAR2
, p_new_password IN VARCHAR2
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
);

procedure login(
  p_username          IN VARCHAR2
, p_change_password  OUT NOCOPY VARCHAR2
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
);


PROCEDURE delete_user(
  p_username      IN VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
);

procedure retrieve_pwd_challenge(
  p_user_party_id       IN NUMBER
, X_USER_PWD_QUESTION   OUT NOCOPY VARCHAR2
, X_USER_PWD_RESPONSE   OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg       OUT NOCOPY VARCHAR2
, x_enc_foundation      OUT NOCOPY VARCHAR2
);

procedure update_pwd_challenge(
  p_user_party_id       IN NUMBER
, P_USER_PWD_QUESTION   IN VARCHAR2
, P_USER_PWD_RESPONSE   IN VARCHAR2
, p_enc_foundation      IN VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg       OUT NOCOPY VARCHAR2
);

procedure retrieve_user_data(
  p_username                        IN VARCHAR2
, x_user_party_id                   OUT NOCOPY NUMBER
, X_USER_NAME_PREFIX                OUT NOCOPY VARCHAR2
, X_USER_NAME_F                     OUT NOCOPY VARCHAR2
, X_USER_NAME_M                     OUT NOCOPY VARCHAR2
, X_USER_NAME_L                     OUT NOCOPY VARCHAR2
, X_USER_NAME_SUFFIX                OUT NOCOPY VARCHAR2
, X_USER_TITLE                      OUT NOCOPY VARCHAR2
, X_USER_EMAIL                      OUT NOCOPY VARCHAR2
, X_USER_COUNTRY_CODE               OUT NOCOPY VARCHAR2
, X_USER_AREA_CODE                  OUT NOCOPY VARCHAR2
, X_USER_PHONE                      OUT NOCOPY VARCHAR2
, X_USER_EXTENSION                  OUT NOCOPY VARCHAR2
, X_USER_FAX_COUNTRY_CODE           OUT NOCOPY VARCHAR2
, X_USER_FAX_AREA_CODE              OUT NOCOPY VARCHAR2
, X_USER_FAX                        OUT NOCOPY VARCHAR2
, X_USER_FAX_EXTENSION              OUT NOCOPY VARCHAR2
, X_USER_ENCODINGOPTION             OUT NOCOPY VARCHAR2
, X_DUMMY_DATA                      OUT NOCOPY VARCHAR2
, X_EXTRA_INFO                      OUT NOCOPY VARCHAR2
, X_ROW_IN_HR                       OUT NOCOPY VARCHAR2
, X_VENDOR_RELATIONSHIP             OUT NOCOPY VARCHAR2
, X_ENTERPRISE_RELATIONSHIP         OUT NOCOPY VARCHAR2
, x_status              OUT NOCOPY VARCHAR2
, x_exception_msg   OUT NOCOPY VARCHAR2
);

END PON_USER_PROFILE_PKG;

 

/
